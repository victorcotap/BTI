export enum category { Airplane = "Airplane", Ground = "Ground Unit", Ship = "Ship", Helicopter = "Helicopter"}
export enum coalition {Blue = 2, Red = 1}
export enum attributes { 
    Fortifications = "Fortifications", 
    Helicopters = "Helicopters",
    Infantry = "New infantry",
    SAM = "SAM",
    SAMRelated = "SAM related",
    AAA = "AAA",
    APC = "APC",
    Armor = "Armored vehicle",
    HeavyArmor = "HeavyArmoredUnits",
    LightArmor = "LightArmoredUnits",
    Artillery = "Artillery",
    Trucks = "Trucks",
    Cars = "Cars",
}

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
    displayName: string,
    attributes: { [key: string]: boolean }
}
