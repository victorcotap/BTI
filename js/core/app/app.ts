import express from 'express';
import liveDataRouter from './liveData';

const app = express()


app.get('/', function(req, res) {
    res.send({"hello" : "world"})
});

app.use('/live', liveDataRouter);

app.listen(3001, function() {
    console.log("Core is online");
});
