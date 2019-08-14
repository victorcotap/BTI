"use strict";
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : new P(function (resolve) { resolve(result.value); }).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = __importDefault(require("express"));
const trackingStore_1 = __importDefault(require("./trackingStore"));
const router = express_1.default.Router();
const cacheTime = 60;
const trackingFilePath = "/BTI/TrackingFile.json";
const store = new trackingStore_1.default(trackingFilePath);
router.get('/', (request, response) => __awaiter(this, void 0, void 0, function* () {
    const currentTime = new Date();
    if (currentTime.getTime() - store.cache.time.getTime() > 30000) {
        console.info('Live data cache is stale, refreshing');
        yield store.readTrackingFile();
    }
    console.log('Live data access');
    response.json({ currentGroups: store.cache.currentGroups });
}));
exports.default = router;
//# sourceMappingURL=liveData.js.map