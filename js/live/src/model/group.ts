export enum category { Airplane = "Airplane", Ground = "Ground Unit", Ship = "Ship"}
export enum coalition {Blue = 2, Red = 1}

export default interface Group {
    alive: boolean,
    category: category,
    coalition: coalition,
    latitude: number,
    longitude: number,
    LLDMS: string,
    LLDDM: string,
    MGRS: string,
    type: string,
    heading: number,
    height: number,
}
