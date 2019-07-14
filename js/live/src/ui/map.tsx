import React from 'react';
import ReactMapboxGl, { Layer, Feature } from "react-mapbox-gl";

const Mapbox = ReactMapboxGl({
    accessToken: "pk.eyJ1IjoidmljdG9yY290YXAiLCJhIjoiY2p4eTdvZjRhMDdpejNtb2FmenRvenk0cCJ9.lf2sq-jELqUvTyPil0tWRA"
});

export default class Map extends React.Component {

    render() {
        return (
            <div>
                <h1>Here is the map</h1>
                <Mapbox
                    style="mapbox://styles/mapbox/streets-v9"
                    center={[42.262198, 42.721665]}
                    containerStyle={{
                        height: "100vh",
                        width: "100vw"
                    }}>
                    <Layer
                        type="symbol"
                        id="marker"
                        layout={{ "icon-image": "marker-15" }}>
                        <Feature coordinates={[42.238633, 42.719814]} />
                        <Feature coordinates={[42.238643, 42.719844]} />
                    </Layer>
                </Mapbox>
            </div>
        )
    }
}
