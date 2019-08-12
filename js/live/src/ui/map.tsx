import React from 'react';
import ReactMapboxGl from "react-mapbox-gl";
import MapboxGl, { MapMouseEvent } from 'mapbox-gl';
import DmsCoordinates from 'dms-conversion';

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
    selectedPoint?: {lat: number, lng: number},
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
        this.setState({selectedGroup: group});
    }
    private groupPopupClose() {
        this.setState({selectedGroup: undefined});
    }
    private mapMouseMove(map: MapboxGl.Map, event: React.SyntheticEvent<MapMouseEvent>) {
        //Todo: add a moving point display top state
    }

    private mapMouseClick(map: MapboxGl.Map, event: any) {
        console.log(event);
        this.setState({selectedPoint: event.lngLat});
    }

    componentDidMount() {
        this.refreshData();
        setInterval(() => this.refreshData(), 30000);
    }

    render() {
        if (!this.state.currentGroups.length) {
            return (
                <h2>Loading...</h2>
            )
        }

        const {selectedGroup, selectedPoint} = this.state;
        const groupLayers = renderLayers(this.state.currentGroups, (group: Group) => this.groupClickHandler(group));
        const heatmapLayer = renderHeatmap(this.state.currentGroups);
        let popup = undefined;
        if (selectedGroup) {
            popup = (<GroupPopup group={selectedGroup} closePopup={() => this.groupPopupClose()} />);
        }
        let cursorCoordinates = (<span>Click on the map to get coordinates</span>);
        if(selectedPoint) {
            const dms = new DmsCoordinates(selectedPoint.lat, selectedPoint.lng);
            cursorCoordinates = (
            <div>
                <span>Latitude {selectedPoint.lat.toFixed(6)}</span><br />
                <span>Longitude {selectedPoint.lng.toFixed(6)}</span><br />
                <span>{dms.toString()}</span>
            </div>
            )
        }
        console.log({cursorCoordinates});

        return (
            <div>
                <h1>Here is the map</h1>
                <Mapbox
                    style={"mapbox://styles/victorcotap/cjypbpdul4n6j1cmpkt13719b"}
                    center={selectedGroup ? [selectedGroup.longitude, selectedGroup.latitude] : [41.644793131899, 42.18450951825]}
                    // zoom={selectedGroup ? [7] : [null]}
                    onMouseMove={(map, event) => this.mapMouseMove(map, event)}
                    onClick={(map, event) => this.mapMouseClick(map, event)}
                    containerStyle={{
                        height: "80vh",
                        width: "100vw"
                    }}>
                    {groupLayers}
                    {/* noop */}
                    {heatmapLayer}
                    {popup}
                </Mapbox>
                {cursorCoordinates}
            </div>
        )
    }
}
