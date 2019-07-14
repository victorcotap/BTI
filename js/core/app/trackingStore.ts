import * as fs from 'fs';
import { promisify } from 'util';
const readFile = promisify(fs.readFile);

import Group from './group';


export interface Cache {
    time: Date,
    groups?: [Group],
    [key: string] : any,
}

export default class TrackingStore {
    filePath: string
    cache: Cache = {time: new Date()}

    constructor(filePath: string) {
        this.filePath = filePath;
        this.readTrackingFile()
    }

    async readTrackingFile() {
        try {
            const buffer = await readFile(this.filePath, {encoding: 'utf-8'})
            const json = JSON.parse(buffer)
            const groups: [Group] = json
            this.cache.currentGroups = groups
            this.cache.time = new Date()
        } catch (error) {
            console.log(`Unable to read file ${this.filePath} error`, error);
        }
    }
}
