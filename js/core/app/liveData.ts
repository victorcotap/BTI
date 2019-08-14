import express from 'express';

import TrackingStore from './trackingStore';

const router = express.Router();
const cacheTime = 60;
const trackingFilePath = "/BTI/TrackingFile.json";

const store = new TrackingStore(trackingFilePath);

router.get('/', async (request, response) => {
    const currentTime = new Date();
    if (currentTime.getTime() - store.cache.time.getTime() > 30000) {
        console.info('Live data cache is stale, refreshing');
        await store.readTrackingFile();
    }

    console.log('Live data access');
    response.json({currentGroups: store.cache.currentGroups});
});

export default router
