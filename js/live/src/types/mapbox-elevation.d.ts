declare module "mapbox-elevation";
{
    function getElevation(tk: string): function(p, cb)
    export = getElevation;
}

declare module "formatcoords";