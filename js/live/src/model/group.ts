export enum category { Airplane = "Airplane", Ground = "Ground Unit", Ship = "Ship", Helicopter = "Helicopter"}
export enum coalition {Blue = 2, Red = 1}
export enum attributes { 
    AAA = "AAA",
    APC = "APC",
    Armor = "Armored vehicle",
    AircraftCarrier = "AircraftCarrier",
    Artillery = "Artillery",
    Cars = "Cars",
    Fortifications = "Fortifications", 
    HeavyArmor = "HeavyArmoredUnits",
    Helicopters = "Helicopters",
    Infantry = "New infantry",
    LightArmor = "LightArmoredUnits",
    SAM = "SAM",
    SAMRelated = "SAM related",
    ShipSAM = "Armed Air Defence",
    Trucks = "Trucks",
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
