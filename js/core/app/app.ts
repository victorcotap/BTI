import express from 'express';
import cors from 'cors';

import config from '../config.json';

import liveDataRouter from './liveData';

const app = express()
app.use(cors());

app.get('/', function(req, res) {
    res.send({"hello" : "world"})
});

app.use('/live', liveDataRouter);

app.listen(config.port, function() {
    console.log("Core is online on 10407");
});
