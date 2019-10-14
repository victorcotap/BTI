import * as fs from 'fs';
import { promisify } from 'util';
const readFile = promisify(fs.readFile);

import Group from '../model/group';


export interface Cache {
    time: Date,
    currentGroups: Group[]
    [key: string] : any,
}

export default class TrackingStore {
    filePath: string
    cache: Cache = {
        time: new Date(),
        currentGroups: Array<Group>()
    }

    constructor(filePath: string) {
        this.filePath = filePath;
        this.readTrackingFile()
    }

    async readTrackingFile() {
        try {
            const buffer = await readFile(this.filePath, {encoding: 'utf-8'})
            const json = JSON.parse(buffer)
            this.cache.currentGroups = Object.values(json)
            this.cache.time = new Date()
        } catch (error) {
            console.log(`Unable to read file ${this.filePath} error`, error);
        }
    }
}
