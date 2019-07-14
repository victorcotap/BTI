"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = __importDefault(require("express"));
const liveData_1 = __importDefault(require("./liveData"));
const app = express_1.default();
app.get('/', function (req, res) {
    res.send({ "hello": "world" });
});
app.use('/live', liveData_1.default);
app.listen(3001, function () {
    console.log("Core is online");
});
//# sourceMappingURL=app.js.map