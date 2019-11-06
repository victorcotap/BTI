import * as fs from 'fs';
import parse from 'csv-parse/lib/sync';
import { promisify } from 'util';
import { delimiter } from 'path';

import Trap, {trapFromCSVEntry} from '../model/trap';

const readFile = promisify(fs.readFile);


export interface Cache {
    time: Date,
    currentTraps: Trap[],
}

export default class AirbossStore {
    filePath: string
    cache: Cache = {
        time: new Date(),
        currentTraps: Array<Trap>(),
    }

    constructor(filePath: string) {
        this.filePath = filePath;
        this.readTrackingFile()
    }

    async readTrackingFile() {
        try {
            const buffer = await readFile(this.filePath, {encoding: 'utf-8'})
            const csv = parse(buffer, {skip_empty_lines: true, columns: true})
            this.cache.currentTraps = csv.map((entry: Object) => trapFromCSVEntry(entry));
            this.cache.time = new Date();
        } catch (error) {
            console.log(`Unable to read file ${this.filePath} error`, error);
        }
    }
}
