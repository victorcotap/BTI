export default interface Trap {
    pilotName: string,
    points: number,
    totalPoints?: number,
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
        points: Number(csv['Points Pass']),
        totalPoints: Number(csv['Points Final']),
        grade: csv.Grade,
        detail: csv.Details,
        wire: Number(csv.Wire),
        timeGroove: Number(csv.Tgroove),
        caseType: Number(csv.Case),
        airframe: csv.Airframe,
        date: new Date(csv['OS Date']),
        wind: csv.Wind,
    }
};
