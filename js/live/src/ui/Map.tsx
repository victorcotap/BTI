import React, { CSSProperties } from 'react';
import ReactMapboxGl from "react-mapbox-gl";
import MapboxGl from 'mapbox-gl';
import DmsCoordinates from 'dms-conversion';

import Group from '../model/group';
import renderLayers from '../utils/groupsRenderer';
import renderHeatmap from '../utils/heatmapRenderer';
import GroupPopup from './GroupPopup';

import config from '../config.json';

const styleMapContainer: CSSProperties = {
    width: '100%',
    height: '100%',
    position: "relative",
    overflow: "hidden"
};

const styleCoordBox: CSSProperties = {
    backgroundColor: "#000000",
    opacity: 0.7,
    padding: "10px",
    borderRadius: "10px",
    color: "#ffffff",
    boxSizing: "border-box",
    position: "absolute",
    zIndex: 2,
    left: 10,
    bottom: 5,
};

const Mapbox = ReactMapboxGl({
    accessToken: "pk.eyJ1IjoidmljdG9yY290YXAiLCJhIjoiY2p4eTdvZjRhMDdpejNtb2FmenRvenk0cCJ9.lf2sq-jELqUvTyPil0tWRA",
    antialias: true,
});

interface Props {
    showHeatmap: boolean,
    showBlue: boolean,
    showAirDefenses: boolean,
    showArmor: boolean,
    showGround: boolean,
}

interface State {
    center: [number, number],
    currentGroups: Group[],
    selectedGroup?: Group,
    selectedPoint?: {lat: number, lng: number},
}

const defaultZoom: [number] = [7];

export default class Map extends React.Component<Props> {
    state: State = {
        center: [40.981280, 42.665656],
        currentGroups: Array<Group>(),
    }
    lastLocation?: [number, number] = undefined

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
    private mapMoveEnd(map: MapboxGl.Map, event: any) {
        const center = map.getCenter()
    }

    private mapMouseClick(map: MapboxGl.Map, event: any) {
        this.setState({selectedPoint: event.lngLat});
    }
 
    componentDidMount() {
        this.refreshData();
        setInterval(() => this.refreshData(), 30000);
    }

    render() {
        const {showAirDefenses, showArmor, showBlue, showGround, showHeatmap} = this.props;
        if (!this.state.currentGroups.length) {
            return (
                <h2>Loading...</h2>
            )
        }

        const {selectedGroup, selectedPoint} = this.state;
        const groupLayers = renderLayers(
            this.state.currentGroups,
            (group: Group) => this.groupClickHandler(group),
            {showAirDefenses, showArmor, showBlue, showGround});
        const heatmapLayer = renderHeatmap(this.state.currentGroups);
        let popup = undefined;
        if (selectedGroup) {
            popup = (<GroupPopup group={selectedGroup} closePopup={() => this.groupPopupClose()} />);
        }
        let cursorCoordinates = (
            <div style={styleCoordBox}><span>Click on the map to get coordinates</span></div>
        );
        if(selectedPoint) {
            const dms = new DmsCoordinates(selectedPoint.lat, selectedPoint.lng);
            cursorCoordinates = (
            <div style={styleCoordBox}>
                <span>Latitude {selectedPoint.lat.toFixed(6)}</span><br />
                <span>Longitude {selectedPoint.lng.toFixed(6)}</span><br />
                <span>{dms.toString()}</span>
            </div>
            )
        }

        return (
            <div style={styleMapContainer}>
                <Mapbox
                    style={"mapbox://styles/victorcotap/cjypbpdul4n6j1cmpkt13719b"}
                    center={this.state.center}
                    zoom={defaultZoom}
                    onMoveEnd={(map, event) => this.mapMoveEnd(map, event)}
                    onClick={(map, event) => this.mapMouseClick(map, event)}
                    containerStyle={{
                        width: "100%",
                        height: "100%"
                    }}>
                    {showHeatmap ? heatmapLayer : undefined}
                    {groupLayers}
                    {/* noop */}
                    {popup}
                </Mapbox>
                {cursorCoordinates}
            </div>
        )
    }
}
