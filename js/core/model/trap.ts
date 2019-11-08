export default interface Trap {
    pilotName: string,
    points: number,
    grade: string,
    detail: string,
    wire: number,
    timeGroove: number,
    caseType: number
    wind: number,
    airframe: string,
    date: Date,
    passMumber?: number,
}

export function trapFromCSVEntry(csv: {[key: string]: any}): Trap {
    return {
        pilotName: csv.Name,
        points: csv['Points Pass'],
        grade: csv.Grade,
        detail: csv.Details,
        wire: csv.Wire,
        timeGroove: csv.Tgroove,
        caseType: csv.Case,
        airframe: csv.Airframe,
        date: new Date(csv['OS Date']),
        wind: csv.Wind,
    }
};
