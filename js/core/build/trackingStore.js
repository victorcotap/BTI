"use strict";
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : new P(function (resolve) { resolve(result.value); }).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
var __importStar = (this && this.__importStar) || function (mod) {
    if (mod && mod.__esModule) return mod;
    var result = {};
    if (mod != null) for (var k in mod) if (Object.hasOwnProperty.call(mod, k)) result[k] = mod[k];
    result["default"] = mod;
    return result;
};
Object.defineProperty(exports, "__esModule", { value: true });
const fs = __importStar(require("fs"));
const util_1 = require("util");
const readFile = util_1.promisify(fs.readFile);
class TrackingStore {
    constructor(filePath) {
        this.cache = {
            time: new Date(),
            currentGroups: Array()
        };
        this.filePath = filePath;
        this.readTrackingFile();
    }
    readTrackingFile() {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const buffer = yield readFile(this.filePath, { encoding: 'utf-8' });
                const json = JSON.parse(buffer);
                this.cache.currentGroups = Object.values(json);
                this.cache.time = new Date();
            }
            catch (error) {
                console.log(`Unable to read file ${this.filePath} error`, error);
            }
        });
    }
}
exports.default = TrackingStore;
//# sourceMappingURL=trackingStore.js.map