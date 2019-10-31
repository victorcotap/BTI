import formatCoords from 'formatcoords';

import Waypoint from '../model/waypoint';

export function distanceBetween(first: Waypoint, second: Waypoint): number {
    if ((first.latitude === second.latitude) && (first.longitude === second.longitude)) {
        return 0;
    }
    else {
        var radlat1 = Math.PI * first.latitude / 180;
        var radlat2 = Math.PI * second.latitude / 180;
        var theta = first.longitude - second.longitude;
        var radtheta = Math.PI * theta / 180;
        var dist = Math.sin(radlat1) * Math.sin(radlat2) + Math.cos(radlat1) * Math.cos(radlat2) * Math.cos(radtheta);
        if (dist > 1) {
            dist = 1;
        }
        dist = Math.acos(dist);
        dist = dist * 180 / Math.PI;
        dist = dist * 60 * 1.1515;
        dist = dist * 0.8684
        return dist;
    }
}

export function bearingBetween(first: Waypoint, second: Waypoint): number {
    // Converts from degrees to radians.
    function toRadians(degrees: number) {
        return degrees * Math.PI / 180;
    };

    // Converts from radians to degrees.
    function toDegrees(radians: number) {
        return radians * 180 / Math.PI;
    }

    const startLat = toRadians(first.latitude);
    const startLng = toRadians(first.longitude);
    const destLat = toRadians(second.latitude);
    const destLng = toRadians(second.longitude);

    const y = Math.sin(destLng - startLng) * Math.cos(destLat);
    const x = Math.cos(startLat) * Math.sin(destLat) -
        Math.sin(startLat) * Math.cos(destLat) * Math.cos(destLng - startLng);
    let brng = Math.atan2(y, x);
    brng = toDegrees(brng);
    return (brng + 360) % 360;
}

export function waypointToDMM(waypoint: Waypoint): {latString: string, lonString: string} {
    const coord = formatCoords({lng: waypoint.longitude, lat: waypoint.latitude});
    const dmmStrings = coord.format('X DD mm', {latLonSeparator: '|', decimalPlaces: 4}).split('|');
    const latString = dmmStrings[0];
    const lonString = dmmStrings[1];
    return {latString, lonString};
}