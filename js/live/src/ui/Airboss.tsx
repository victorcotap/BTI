import React, { CSSProperties } from 'react';

import Trap from '../model/trap';

import config from '../config.json';

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
    borderCollapse: 'collapse',
    minWidth: '95%',
}

const styleCell: CSSProperties = {
    height: '30px',
}

interface Props { }
interface State {
    currentTraps: Trap[],
}

export default class Airboss extends React.Component<Props, State> {
    state: State = {
        currentTraps: Array<Trap>(),
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
                this.setState({ currentTraps: traps })
            }
            console.log(traps);
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
            return { backgroundColor: 'green' }
        } else if (grade >= 3.0) {
            return { backgroundColor: '#006400' }
        } else if (grade >= 2.0) {
            return { backgroundColor: 'gray' }
        } else if (grade >= 1.0) {
            return { backgroundColor: 'orange' }
        }
        return { backgroundColor: 'red' }

    }

    render() {
        return (
            <div style={styleAirboss}>
                <table style={styleTable}>
                    <thead>
                        <tr style={{color: '#000000'}}>
                            <th>Pilot Name</th>
                            <th>Airframe</th>
                            <th>Points</th>
                            <th>Grade</th>
                            <th>Details</th>
                            <th>Wire</th>
                            <th>Time in groove</th>
                            <th>CASE</th>
                            <th>Wind over deck</th>
                        </tr>
                    </thead>
                    <tbody>
                        {this.state.currentTraps.map((trap: Trap) => {
                            const gradeStyle = this.styleForGrade(trap.points)
                            return (
                                <tr style={{ ...styleCell, ...gradeStyle}} key={trap.pilotName + trap.grade + trap.detail}>
                                    <td>{trap.pilotName}</td>
                                    <td>{trap.airframe}</td>
                                    <td>{trap.points}</td>
                                    <td>{trap.grade}</td>
                                    <td>{trap.detail}</td>
                                    <td>{trap.wire}</td>
                                    <td>{trap.timeGroove}</td>
                                    <td>{trap.caseType}</td>
                                    <td>{trap.wind}</td>
                                </tr>
                            )
                        })}
                    </tbody>
                </table>

            </div>
        )
    }
}