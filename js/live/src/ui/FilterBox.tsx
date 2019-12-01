import React, { CSSProperties } from 'react';

import RedGround from '../assets/Red-Ground.png';
import RedSAM from '../assets/Red-SAM.png';
import RedArmor from '../assets/Red-Armor.png';
import BlueGround from '../assets/Blue-Ground.png';

const styleFilterBox: CSSProperties = {
    display: 'flex',
    flexDirection: 'column',
    alignItems: 'flex-start',
    backgroundColor: "#000000",
    opacity: 0.7,
    padding: "10px",
    borderRadius: "10px",
    color: "#00DD00",
    boxSizing: "border-box",
    position: "absolute",
    zIndex: 2,
    left: 10,
    top: 10,
};

const styleFiltersColumn: CSSProperties = {
    display: 'flex',
    flexDirection: 'column',
    alignItems: 'flex-start',
    marginTop: '10px',
}

const styleFilter: CSSProperties = {
    padding: "3px 5px 3px 5px",
}

const styleButton: CSSProperties = {
    boxSizing: "border-box",
    margin: "0 0px 0px 0",
    backgroundColor: "#111111",
    color: "#00DD00",
    height: "1.5rem",
    borderRadius: "5px",
    borderColor: '#00FF00',
}

const styleImage: CSSProperties = {
    width: 20,
    height: 20,
    margin: '0 5px 0 5px',
}

interface Props {
    onFilterSelection: (filterKey: string, value: boolean) => void,
    showHeatmap: boolean,
    showBlue: boolean,
    showAirDefenses: boolean,
    showArmor: boolean,
    showGround: boolean,
}

interface State {
    showFilters: boolean,
}

export default class FilterBox extends React.Component<Props> {
    state: State = {
        showFilters: false,
    }
    render() {
        return (
            <div style={styleFilterBox}>
                <button style={styleButton} onClick={(event) => this.setState({ showFilters: !this.state.showFilters })}>Show Map Filters</button>
                {this.state.showFilters ? (
                    <div style={styleFiltersColumn}>
                        <div style={styleFilter}>
                            <input type="checkbox" name="heatmap" defaultChecked={true} onChange={(event) => this.props.onFilterSelection('showHeatmap', event.target.checked)} />
                            <label> Heatmap</label>
                        </div>
                        <div style={styleFilter}>
                            <input type="checkbox" name="blue" defaultChecked={true} onChange={(event) => this.props.onFilterSelection('showBlue', event.target.checked)} />
                            <img style={styleImage} src={BlueGround} alt={''} />
                            <label> BLUFOR</label>
                        </div>
                        <div style={styleFilter}>
                            <input type="checkbox" name="air-defenses" defaultChecked={true} onChange={(event) => this.props.onFilterSelection('showAirDefenses', event.target.checked)} />
                            <img style={styleImage} src={RedSAM} alt={''} />
                            <label> Air Defenses</label>
                        </div>
                        <div style={styleFilter}>
                            <input type="checkbox" name="armor" defaultChecked={true} onChange={(event) => this.props.onFilterSelection('showArmor', event.target.checked)} />
                            <img style={styleImage} src={RedArmor} alt={''} />
                            <label> Armor</label>
                        </div>
                        <div style={styleFilter}>
                            <input type="checkbox" name="ground" defaultChecked={true} onChange={(event) => this.props.onFilterSelection('showGround', event.target.checked)} />
                            <img style={styleImage} src={RedGround} alt={''} />
                            <label> Ground forces</label>
                        </div>
                        <div style={styleFilter}>
                            <input type="checkbox" name="approachChart" defaultChecked={false} onChange={(event) => this.props.onFilterSelection('showApproachChart', event.target.checked)} />
                            <label> Approach Chart</label>
                        </div>
                    </div>
                ) : undefined}
            </div>
        )
    }
}