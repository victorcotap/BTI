import React from 'react';
import ReactMapboxGl, { Layer, Feature } from "react-mapbox-gl";

import Group from '../model/group';

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
            if (currentGroups) {
                this.setState({ currentGroups })
            }
            console.log(currentGroups);
        } catch (error) {
            console.log(error);
        }
    }

    componentDidMount() {
        this.refreshData()
    }

    renderGroup(group: Group) {
        return (
            <Feature coordinates={[group.longitude, group.latitude]} />
        );
    }

    render() {
        console.log(this.state.currentGroups);

        if (!this.state.currentGroups.length) {
            return (
                <h2>Loading...</h2>
            )
        }
        const groups = this.state.currentGroups.map((group) => { return this.renderGroup(group) })

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
                        {groups}
                    </Layer>
                </Mapbox>
            </div>
        )
    }
}
