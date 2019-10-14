
export interface CSARDisabled {
    timeout: number,
    unitId: string,
    desc: string,
    name: string,
    noPilot: boolean
}

export default interface CSARRecord {
    disabled: boolean,
    crashedPlayerName?: string,
    rescuePlayerName?: string,
}
