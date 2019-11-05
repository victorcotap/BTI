export enum WaypointType {waypoint, DMPI}

export default interface Waypoint {
    latitude: number,
    longitude: number,
    elevation: number,
    name?: string,
    type: WaypointType,
    color?: string,
}
