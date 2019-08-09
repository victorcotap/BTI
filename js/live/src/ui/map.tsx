import React from 'react';
import ReactMapboxGl from "react-mapbox-gl";

import Group from '../model/group';
import renderLayers from '../utils/groupsRenderer';
import renderHeatmap from '../utils/heatmapRenderer';
import GroupPopup from './GroupPopup';

import './map.css';
import config from '../config.json';

const Mapbox = ReactMapboxGl({
    accessToken: "pk.eyJ1IjoidmljdG9yY290YXAiLCJhIjoiY2p4eTdvZjRhMDdpejNtb2FmenRvenk0cCJ9.lf2sq-jELqUvTyPil0tWRA"
});

interface State {
    currentGroups: Group[],
    selectedGroup?: Group,
}

export default class Map extends React.Component {
    state: State = {
        currentGroups: Array<Group>(),
    }


    private async fetchData() {
        return fetch(config.coreTunnel + "/live", {
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
    private groupClickHandler(group: Group) {
        this.setState({selectedGroup: group})
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

        const {selectedGroup} = this.state;
        const groupLayers = renderLayers(this.state.currentGroups, (group: Group) => this.groupClickHandler(group));
        const heatmapLayer = renderHeatmap(this.state.currentGroups);
        let popup = undefined;
        if (selectedGroup) {
            console.log(selectedGroup);
            popup = (<GroupPopup group={selectedGroup} />);
        }
        
        return (
            <div>
                <h1>Here is the map</h1>
                <Mapbox
                    style={"mapbox://styles/victorcotap/cjypbpdul4n6j1cmpkt13719b"}
                    center={selectedGroup ? [selectedGroup.longitude, selectedGroup.latitude] : [41.644793131899, 42.18450951825]}
                    // zoom={selectedGroup ? [7] : [null]}
                    containerStyle={{
                        height: "80vh",
                        width: "90vw"
                    }}>
                    {groupLayers}
                    {/* noop */}
                    {heatmapLayer}
                    {popup ? popup : null }
                </Mapbox>
            </div>
        )
    }
}
