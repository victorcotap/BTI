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
    slots: Array<Slot>
}

type BookingQueryResponse = {
    bookings: BookingQueryType[]
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
    fromDate: number,
    toDate: string,
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
}
`

const slotMutation = `
mutation slotMutation($slots: UpdateServerSlots!) {
    updateServerSlots(input: $slots)
}
`

export default class SlotStore {
    filepath: string
    slotFilePath: string
    cache: Cache = {
        time: new Date(),
        bookings: Array<BookingQueryType>(),
        slots: Array<Slot>(),
    }
    client: GraphQLClient

    constructor(filepath: string, slotFilePath: string) {
        this.filepath = filepath;
        this.slotFilePath = slotFilePath;
        // setInterval(() => this.fetchServerSlotsBooking(), 3000);
        setInterval(() => this.reportServerSlots(), 3000);
        this.client = new GraphQLClient(ENDPOINT, { headers: { serverAPIKey: config.DCSSuperCareerApiKey }, mode: "cors" })
    }

    async readSlotFile() {
        console.log("accessing slot file")
        try {
            const buffer = await readFile(this.slotFilePath, { encoding: 'utf-8' })
            const json = JSON.parse(buffer)
            this.cache.slots = json["slots"]
            this.cache.time = new Date()
        } catch (error) {
            console.log(`Unable to read file ${this.slotFilePath} error`, error);
        }
    }

    fetchServerSlotsBooking = async () => {
        try {
            const data = await this.client.request<BookingQueryResponse>(query, { serverID: 'testServer' })
            this.cache.bookings = data.bookings
            console.log(data)
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
            console.info("Reported " + strippedSlots.length + " slots")
        } catch (error) {
            console.error(error)
        }
    }

    generateBookingJSON = async () => {
        const transformedBooking = this.cache.bookings.map((booking) => {
            const fromDateTimestamp = Math.round(new Date(booking.fromDate).getTime() / 1000)
            const toDateTimestamp = Math.round(new Date(booking.fromDate).getTime() / 1000)
            return {
                ...booking,
                fromDate: fromDateTimestamp,
                toDate: toDateTimestamp
            }
        })

        try {
            writeFile(this.filepath, JSON.stringify(transformedBooking))
        } catch (error) {
            console.error(error)
        }
    }
}