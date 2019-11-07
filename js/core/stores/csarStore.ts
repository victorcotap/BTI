import * as fs from 'fs';
import { promisify } from 'util';
const readFile = promisify(fs.readFile);

import CSARRecord from '../model/csarSlot';
import {CSARDisabled} from '../model/csarSlot';


export interface Cache {
    time: Date,
    slots: String[],
    records?: { [key: string] : CSARRecord },
    disabled?: { [key: string] : CSARDisabled },
}

export default class CSARStore {
    filePath: string
    cache: Cache = {
        time: new Date(),
        slots: Array<String>(),
    }

    constructor(filePath: string) {
        this.filePath = filePath;
        this.readTrackingFile()
    }

    async readTrackingFile() {
        try {
            const buffer = await readFile(this.filePath, {encoding: 'utf-8'})
            const json = JSON.parse(buffer)
            this.cache.slots = json["slots"]
            this.cache.records = json["records"]
            this.cache.disabled = json["disabled"]
            this.cache.time = new Date()
        } catch (error) {
            console.log(`Unable to read file ${this.filePath} error`, error);
        }
    }
}