import * as fs from 'fs';
import parse from 'csv-parse/lib/sync';
import Discord from 'discord.js';

import { promisify } from 'util';
import { delimiter } from 'path';

import config from '../config.json';

import Trap, {trapFromCSVEntry} from '../model/trap';

const readFile = promisify(fs.readFile);
const client = new Discord.Client()
let channel: Discord.Channel | undefined;
client.on('ready', () => {
    channel = client.channels.get(config.DiscordChannelID);
});
client.login(config.DiscordToken);

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
        this.readTrackingFile(true)
        setInterval(() => this.readTrackingFile(false), 30000);
    }

    private async  sendNewTrapToDiscord(trap: Trap) {
        if (channel) {
            const embed = new Discord.RichEmbed();
            // embed.setTitle('New entry on the Greenie Board');
            // embed.setDescription("Here is what the LSO has to say");
            embed.setFooter('Provided by MiniBoss');
            embed.addField("Pilot Name", trap.pilotName, true);
            embed.addField("Airframe", trap.airframe, true);
            // embed.addField("Points", trap.points, true);
            embed.addField('Grade', trap.grade, true);
            embed.addField('Details', trap.detail, true);
            embed.addField('Wire', trap.wire, true);
            embed.addField('Time in groove', trap.timeGroove, true);
            // embed.addField('Wind', trap.wind, true);

            try {
                //@ts-ignore
                await channel.send('New entry on the Greenie Board!', {embed});
            } catch (error) {
                console.warn(error);
            }
        }
    }

    async readTrackingFile(firstTime: boolean) {
        try {
            const buffer = await readFile(this.filePath, {encoding: 'utf-8'})
            const csv = parse(buffer, {quote: '', skip_empty_lines: true, columns: true})
            const newTraps: Trap[] = csv.map((entry: Object) => trapFromCSVEntry(entry));
            const orderedTraps = newTraps.sort((a, b) => b.date.getTime() - a.date.getTime())
            if (!firstTime && this.cache.currentTraps.length !== orderedTraps.length) {
                console.log('sending new trap');
                this.sendNewTrapToDiscord(orderedTraps[0]);
            }
            this.cache.currentTraps = orderedTraps;
            this.cache.time = new Date();
        } catch (error) {
            console.warn(`Unable to read file ${this.filePath} error`, error);
        }
    }
}
