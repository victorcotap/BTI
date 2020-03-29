import * as fs from 'fs';
import { promisify } from 'util'
const writeFile = promisify(fs.writeFile)
import request, { GraphQLClient } from 'graphql-request';

import config from '../config.json';

const ENDPOINT = 'http://localhost:4000/graphql'

export interface Cache {
    time: Date,
    bookings: Array<BookingQueryType>,
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

const query = `
query bookingQuery($serverID: ID!) {
    bookings(serverID: $serverID) {
    pilot {name, playerUCID}
    slot {nameKey}
    fromDate
    toDate
}}
`

export default class SlotStore {
    filepath: string
    cache: Cache = {
        time: new Date(),
        bookings: Array<BookingQueryType>(),
    }
    client: GraphQLClient

    constructor(filepath: string) {
        this.filepath = filepath;
        setInterval(() => this.fetchServerSlotsBooking(), 3000);
        this.client = new GraphQLClient(ENDPOINT)
    }

    fetchServerSlotsBooking = async () => {
        try {
            const data = await this.client.request<BookingQueryResponse>(query, {serverID: 'testServer'})
            this.cache.bookings = data.bookings
            console.log(data)
            this.generateBookingJSON()
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