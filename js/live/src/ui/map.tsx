import React from 'react';
import ReactMapboxGl from "react-mapbox-gl";

import Group from '../model/group';
import renderLayers from '../utils/layerRenderer';

const Mapbox = ReactMapboxGl({
    accessToken: "pk.eyJ1IjoidmljdG9yY290YXAiLCJhIjoiY2p4eTdvZjRhMDdpejNtb2FmenRvenk0cCJ9.lf2sq-jELqUvTyPil0tWRA"
});

interface State {
    currentGroups: Group[]
}

export default class Map extends React.Component {
    state: State = {
        currentGroups: Array<Group>()
    }


    private async fetchData() {
        return fetch("http://localhost:3001/live", {
            method: 'GET',
            mode: 'cors',
            headers: {
                'Content-Type': 'application/json',
            },
        })
    }
    async refreshData() {
        try {
            const newData = await this.fetchData()
            const newJSON = await newData.json()
            const { currentGroups } = newJSON;
            const groups: Group[] = currentGroups;
            if (groups) {
                this.setState({ currentGroups: groups })
            }
        } catch (error) {
            console.log(error);
        }
    }

    componentDidMount() {
        this.refreshData()
    }

    render() {
        if (!this.state.currentGroups.length) {
            return (
                <h2>Loading...</h2>
            )
        }
        const layers = renderLayers(this.state.currentGroups);
        return (
            <div>
                <h1>Here is the map</h1>
                <Mapbox
                    style={"mapbox://styles/victorcotap/cjypbpdul4n6j1cmpkt13719b"}
                    center={[42.262198, 42.721665]}
                    containerStyle={{
                        height: "100vh",
                        width: "100vw"
                    }}>
                    {layers}
                </Mapbox>
            </div>
        )
    }
}
