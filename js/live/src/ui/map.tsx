import React from 'react';
import ReactMapboxGl, { Layer, Feature } from "react-mapbox-gl";

import Group, { category, coalition } from '../model/group';

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
            <Feature coordinates={[group.longitude, group.latitude]} properties={group} />
        );
    }

    renderLayers(groups: Group[]) {
        const redGroundGroups = groups.filter((group) => group.category === category.Ground && group.coalition === coalition.Red).map((group) => this.renderGroup(group));
        const redGroundLayer = (<Layer
            type="symbol"
            id="redGroundLayer"
            layout={{ "icon-image": "bus-15" }}>
            {redGroundGroups}
        </Layer>)
        const unitsLayers = [redGroundLayer]

        const redAirGroups = groups.filter((group) => group.category === category.Airplane && group.coalition === coalition.Red).map((group) => this.renderGroup(group));
        const redAirLayer = (<Layer
            type="symbol"
            id="redAirLayer"
            layout={{ "icon-image": "airport-15" }}>
            {redAirGroups}
        </Layer>)
        unitsLayers.push(redAirLayer)

        const blueGroundGroups = groups.filter((group) => group.category === category.Ground && group.coalition === coalition.Blue).map((group) => this.renderGroup(group));
        const blueGroundLayer = (<Layer
            type="symbol"
            id="blueGroundLayer"
            layout={{ "icon-image": "bus-15" }}>
            {blueGroundGroups}
        </Layer>)
        unitsLayers.push(blueGroundLayer)

        const blueAirGroups = groups.filter((group) => group.category === category.Airplane && group.coalition === coalition.Blue).map((group) => this.renderGroup(group));
        const blueAirLayer = (<Layer
            type="symbol"
            id="blueAirLayer"
            layout={{ "icon-image": "airfield-15" }}>
            {blueAirGroups}
        </Layer>)
        unitsLayers.push(blueAirLayer);

        return unitsLayers;
    }

    render() {
        console.log(this.state.currentGroups);

        if (!this.state.currentGroups.length) {
            return (
                <h2>Loading...</h2>
            )
        }
        const layers = this.renderLayers(this.state.currentGroups);
        return (
            <div>
                <h1>Here is the map</h1>
                <Mapbox
                    style="mapbox://styles/victorcotap/cjypbpdul4n6j1cmpkt13719b"
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
