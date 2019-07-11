import React from 'react';
import ReactMapGL from 'react-map-gl';

export default class Map extends React.Component {
    state = {
        viewport : {
            width: 1000,
            height: 1000,
            latitude: 37.7577,
            longitude: -122.4376,
            zoom: 8,
        }
    }

    render() {
        return (
            <div>
                <h1>Here is the map</h1>
                <ReactMapGL 
                    {...this.state.viewport} 
                    onViewportChange={(viewport) => this.setState({viewport})}
                    mapboxApiAccessToken="pk.eyJ1IjoidmljdG9yY290YXAiLCJhIjoiY2p4eTdvZjRhMDdpejNtb2FmenRvenk0cCJ9.lf2sq-jELqUvTyPil0tWRA"
                />
            </div>
            
        )
    }
}
