import express from 'express';

import TrackingStore from '../stores/trackingStore';
import CSARStore from '../stores/csarStore';
import AirbossStore from '../stores/airbossStore';

import config from '../config.json';
import SlotStore from '../stores/slotStore';

const router = express.Router();
const cacheTime = 60;
const trackingFilePath = config.pathToTrackingFile;
const CSARFilePath = "/BTI/Tracking/CSARTracking.json";
const SlotsFilePath = config.pathToSlotFile;
const LogbookFilePath = config.pathToLogbookFile;

const trackingStore = new TrackingStore(trackingFilePath);
const csarStore = new CSARStore(CSARFilePath);

router.get('/', async (request, response) => {
    const currentTime = new Date();
    if (currentTime.getTime() - trackingStore.cache.time.getTime() > 30000) {
        console.info('Live data cache is stale, refreshing');
        await trackingStore.readTrackingFile();
    }

    console.info('Live data access', new Date());
    response.json({currentGroups: trackingStore.cache.currentGroups});
});

router.get('/csar', async (request, response) => {
    const currentTime = new Date();
    if (currentTime.getTime() - csarStore.cache.time.getTime() > 30000) {
        console.info('CSAR data cache is stale, refreshing');
        await csarStore.readTrackingFile();
    }

    console.info('CSAR data access', new Date());
    response.json({
        slots: csarStore.cache.slots,
        disabled: csarStore.cache.disabled,
        records: csarStore.cache.records,
    });
});

if (config.SlotsEnabled) {
    const slotStore = new SlotStore(config.DCSSupercareerFilepath, SlotsFilePath, LogbookFilePath);
    router.get('/slots', async (request, response) => {
        const currentTime = new Date();
        if (currentTime.getTime() - slotStore.cache.time.getTime() > 30000) {
            console.info('Slot data cache is stale, refreshing');
            await slotStore.readSlotFile();
        }

        console.info('Slot data access', new Date());
        response.json({
            slots: slotStore.cache.slots
        });});

}

if (config.DiscordEnabled) {
    const airbossStore = new AirbossStore(config.pathToGreenieBoardCSV)
    router.get('/airboss', async (request, response) => {
        console.info('AIRBOSS data access', new Date());
        response.json({currentTraps: airbossStore.cache.currentTraps});
    });
}

export default router
