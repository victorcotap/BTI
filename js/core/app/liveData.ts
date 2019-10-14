import express from 'express';

import TrackingStore from '../stores/trackingStore';
import CSARStore from '../stores/csarStore';


const router = express.Router();
const cacheTime = 60;
const trackingFilePath = "/BTI/Tracking/TrackingFile.json";
const CSARFilePath = "/BTI/Tracking/CSARTracking.json";

const trackingStore = new TrackingStore(trackingFilePath);
const csarStore = new CSARStore(CSARFilePath);


router.get('/', async (request, response) => {
    const currentTime = new Date();
    if (currentTime.getTime() - trackingStore.cache.time.getTime() > 30000) {
        console.info('Live data cache is stale, refreshing');
        await trackingStore.readTrackingFile();
    }

    console.log('Live data access');
    response.json({currentGroups: trackingStore.cache.currentGroups});
});

router.get('/csar', async (request, response) => {
    const currentTime = new Date();
    if (currentTime.getTime() - csarStore.cache.time.getTime() > 30000) {
        console.info('CSAR data cache is stale, refreshing');
        await csarStore.readTrackingFile();
    }

    console.log('CSAR data access');
    response.json({
        slots: csarStore.cache.slots,
        disabled: csarStore.cache.disabled,
        records: csarStore.cache.records,
    });
});
export default router
