import React, { CSSProperties } from 'react';

import Trap from '../model/trap';

import config from '../config.json';

const MILISECONDSINDAY = 86400000;
const NUMBEROFTRAPS = 10;
const NUMBEROFDAYS = 30;

const styleAirboss: CSSProperties = {
    display: 'flex',
    justifyContent: 'center',
    backgroundColor: "#DDDDDD",
    borderRadius: "30px",
    marginTop: "30px",
    marginLeft: '15px',
    marginRight: '15px',
    padding: "20px 20px 20px 20px",
}

const styleTable: CSSProperties = {
    // borderCollapse: 'collapse',
    minWidth: '95%',
}

const styleCell: CSSProperties = {
    borderColor: 'black',
    border: 1,
}

interface Props { }
interface State {
    currentTraps: Trap[],
    groupedTraps: { [key: string]: [Trap] }
    daysLimit: number
}

export default class Airboss extends React.Component<Props, State> {
    state: State = {
        currentTraps: Array<Trap>(),
        groupedTraps: {},
        daysLimit: NUMBEROFDAYS,
    }

    private async fetchData() {
        return fetch(config.coreTunnel + "/live/airboss", {
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
            const { currentTraps } = newJSON;
            const traps: Trap[] = currentTraps;
            if (traps) {
                let groupedTraps: { [key: string]: [Trap] } = {};
                const last30Traps = traps.filter((trap) => Date.now() - new Date(trap.date).getTime() < MILISECONDSINDAY * this.state.daysLimit)
                last30Traps.forEach((trap) => {
                    if (!groupedTraps[trap.pilotName]) {
                        groupedTraps[trap.pilotName] = [trap];
                    } else {
                        groupedTraps[trap.pilotName].push(trap);
                    }
                });
                this.setState({ currentTraps: traps, groupedTraps })
            }
        } catch (error) {
            console.log(error);
        }
    }

    componentDidMount() {
        this.refreshData();
        setInterval(() => this.refreshData(), 30000);
    }

    private styleForGrade(grade: number): CSSProperties {
        if (grade >= 5.0) {
            return { backgroundColor: '#fa5ea7' }
        } else if (grade >= 4.0) {
            return { backgroundColor: 'green' }
        } else if (grade >= 3.0) {
            return { backgroundColor: '#006400' }
        } else if (grade >= 2.0) {
            return { backgroundColor: 'gray' }
        } else if (grade >= 1.0) {
            return { backgroundColor: 'orange' }
        } else if (grade < 0.0) {
            return { backgroundColor: 'gray' }
        }
        return { backgroundColor: 'red' }

    }

    render() {
        const pilotRows = [];
        for (let [pilotName, traps] of Object.entries(this.state.groupedTraps)) {
            let pilotAverage = 0;
            let validTrapCount = 0;
            let lastTraps = traps.slice(0, NUMBEROFTRAPS - 1);
            lastTraps = lastTraps.reverse();
            lastTraps.forEach((trap) => {
                if (trap.points >= 0){
                    pilotAverage = pilotAverage + trap.points;
                    validTrapCount++;
                }
            })
            pilotAverage = pilotAverage / validTrapCount;
            let trapColumns = [];
            for (let index = 0; index < NUMBEROFTRAPS; index++) {
                const trap = lastTraps[index];
                if (trap) {
                    trapColumns.push((<td key={pilotName + index.toString()} style={{...styleCell, ...this.styleForGrade(trap.points)}}>{trap.grade}</td>))
                } else {
                    trapColumns.push(<td key={pilotName + index.toString()}></td>)
                }
            }

            pilotRows.push(
                <tr style={{height: '45px'}} key={pilotName}>
                    <td style={{color: 'black'}}>{pilotName}</td>
                    <td style={{color: 'black'}}>{pilotAverage.toFixed(1)}</td>
                    {trapColumns}
                </tr>
            )
        }

        const trapColumnsHeader = [];
        for (let index = 0; index < 15; index++) {
            trapColumnsHeader.push((<th key={index}></th>))
        }
        return (
            <div style={styleAirboss}>
                <table style={styleTable}>
                    <thead>
                        <tr style={{ color: '#000000' }}>
                            <th>Pilot Name</th>
                            <th>Average</th>
                            {trapColumnsHeader}
                        </tr>
                    </thead>
                    <tbody>
                        {pilotRows}
                    </tbody>
                </table>
            </div>
        );
    }
}