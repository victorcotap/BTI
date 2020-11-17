import * as fs from 'fs';
import { promisify } from 'util'
const writeFile = promisify(fs.writeFile)
const readFile = promisify(fs.readFile);
import request, { GraphQLClient } from 'graphql-request';

import config from '../config.json';

const ENDPOINT = 'http://' + config.DCSSuperCareerHost

export interface Cache {
    time: Date,
    bookings: Array<BookingQueryType>,
    slotRules: Array<SlotRuleType>,
    slots: Array<Slot>
    savedLogbook: Logbook
}

type Logbook = {
    [ucid: string]: { flights: LogbookEntry[] }
}

type LogbookEntry = {
    id: string
    slotName: string
    slotType: string
    takeoffTime: number
    takeoffAirdrome: string | undefined
    landingTime: number
    landingAirdrome: string | undefined
    outcome: string
    friendlyFire: number
    score: number
    vehicles: number
    planes: number
    ships: number
}

type BookingQueryResponse = {
    bookings: BookingQueryType[],
    server: { slotRules: SlotRuleType[] },
}
type BookingQueryType = {
    id: string,
    slot: {
        nameKey: string,
    },
    pilot: {
        name: string,
        playerUCID: string,
    },
    fromDate: string,
    toDate: string,
}
type SlotRuleType = {
    match: string,
    block: boolean,
}

type Slot = {
    slotName: string,
    groupName?: string,
    typeName?: string,
    playerName?: string,
}

const query = `
query bookingQuery($serverID: ID!) {
    bookings(serverID: $serverID) {
        pilot {name, playerUCID}
        slot {nameKey}
        fromDate
        toDate
    }
    server(serverID: $serverID) {
        slotRules {
            match
            block
        }
    }
}
`

const slotMutation = `
mutation slotMutation($slots: UpdateServerSlots!) {
    updateServerSlots(input: $slots)
}
`
const logbookMutation = `
mutation logbookMutation($entry: LogbookEntryInput!) {
    addLogbookEntry(input: $entry)
}
`

export default class SlotStore {
    filepath: string
    slotFilePath: string
    logbookFilePath: string
    cache: Cache = {
        time: new Date(),
        bookings: Array<BookingQueryType>(),
        slotRules: Array<SlotRuleType>(),
        slots: Array<Slot>(),
        savedLogbook: {},
    }
    client: GraphQLClient

    constructor(filepath: string, slotFilePath: string, logbookFilePath: string) {
        this.filepath = filepath;
        this.slotFilePath = slotFilePath;
        this.logbookFilePath = logbookFilePath;
        setInterval(() => this.fetchServerSlotsBooking(), 150000);
        setTimeout(() => this.reportServerLogbook(true), 500);
        setInterval(() => this.reportServerLogbook(false), 150000);
        this.client = new GraphQLClient(ENDPOINT, { headers: { serverAPIKey: config.DCSSuperCareerApiKey }, mode: "cors" })
    }

    async readSlotFile() {
        console.log("accessing slot file", this.slotFilePath)
        try {
            const buffer = await readFile(this.slotFilePath, { encoding: 'utf-8' })
            const json = JSON.parse(buffer)
            this.cache.slots = json["slots"]
            this.cache.time = new Date()
        } catch (error) {
            console.log(`Unable to read file ${this.slotFilePath} error`, error);
        }
    }
    async readLogbookFile() {
        console.log("accessing logbook file", this.logbookFilePath)
        try {
            const buffer = await readFile(this.logbookFilePath, { encoding: 'utf-8' })
            const json = JSON.parse(buffer)
            return json
        } catch (error) {
            console.log(`Unable to read file ${this.slotFilePath} error`, error);
        }
    }


    fetchServerSlotsBooking = async () => {
        try {
            const data = await this.client.request<BookingQueryResponse>(query, { serverID: config.DCSSuperCareerServerName })
            this.cache.bookings = data.bookings
            this.cache.slotRules = data.server.slotRules
            this.generateBookingJSON()
        } catch (error) {
            console.error(error)
        }
    }

    reportServerSlots = async () => {
        await this.readSlotFile()
        const strippedSlots = this.cache.slots.map(s => s.slotName)
        try {
            const result = await this.client.request(slotMutation, { slots: { slotNames: strippedSlots } })
        } catch (error) {
            console.error(error)
        }
    }

    reportServerLogbook = async (firstTime: boolean) => {
        const logbook = await this.readLogbookFile()
        if (firstTime) {
            this.cache.savedLogbook = logbook
        } else {
            try {
                this.computeSendNewLogbookEntries(logbook)
                this.cache.savedLogbook = logbook
            } catch (error) {
                console.error("Error sending logbook", error)
            }
        }
    }

    computeSendNewLogbookEntries = async (logbook: Logbook) => {
        for (const playerUCID in logbook) {
            const newLogbookEntries: LogbookEntry[] = []
            const pilotLogbook = logbook[playerUCID];
            const savedPilotLogbook = this.cache.savedLogbook[playerUCID];
            pilotLogbook.flights.forEach((flight) => {
                const found = savedPilotLogbook?.flights.findIndex((savedFlight) => flight.id === savedFlight.id)
                if (found === -1) { newLogbookEntries.push(flight) }
            })
            if (newLogbookEntries.length) {
                 try {
                    const result = await this.client.request(logbookMutation, { entry: { flights: newLogbookEntries, playerUCID } })
                } catch (error) {
                    console.error('Cannot process flight for pilot', error )
                    throw error
                }
            }
        }
    }

    generateBookingJSON = async () => {
        const transformedBooking = this.cache.bookings.map((booking) => {
            const fromDateTimestamp = Math.round(new Date(parseInt(booking.fromDate)).getTime() / 1000)
            const toDateTimestamp = Math.round(new Date(parseInt(booking.toDate)).getTime() / 1000)
            return {
                ...booking,
                fromDate: fromDateTimestamp,
                toDate: toDateTimestamp
            }
        })
        const final = {
            bookings: transformedBooking,
            slotRules: this.cache.slotRules,
        }
        try {
            writeFile(this.filepath, JSON.stringify(final))
        } catch (error) {
            console.error(error)
        }
    }
}