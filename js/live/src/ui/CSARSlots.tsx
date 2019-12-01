import React, { CSSProperties } from 'react';

import CSARRecord, { CSARDisabled } from '../model/csarSlot';

import config from '../config.json';

const styleHeader: CSSProperties = {
    display: "flex",
    flexDirection: "row",
    justifyContent: 'space-between',
    paddingBottom: '10px',
    fontWeight: "bold"
}

const styleCell: CSSProperties = {
    display: "flex",
    flexDirection: "row",
    justifyContent: 'space-between',
    padding: "0 0 2px 0",
    borderBottom: "1px solid rgba(255,255,255,0.2)",
}

interface CSARSlotsResponse {
    slots: string[],
    disabled?: { [key: string]: CSARDisabled },
    records?: { [key: string]: CSARRecord },
}

export default class CSARSlots extends React.Component {

    state: CSARSlotsResponse = {
        slots: Array<string>(),
        disabled: undefined,
        records: undefined,
    }

    private async fetchData() {
        return fetch(config.coreTunnel + "/live/csar", {
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
            const response: CSARSlotsResponse = newJSON
            this.setState(response);
        } catch (error) {
            console.log(error);
        }
    }

    componentDidMount() {
        this.refreshData();
        setInterval(() => this.refreshData(), 30000);
    }

    private renderDisabledRecord(slot: string): { disabled: boolean, message: string } {
        if (!this.state.disabled) { return { disabled: false, message: "OK" } }

        const disabledCSAR = this.state.disabled[slot];
        const disabled = disabledCSAR !== undefined;
        let disabledString = !disabled ? "OK" : "Disabled"

        if (this.state.records && this.state.records[slot]) {
            const record = this.state.records[slot]
            disabledString = disabled ? `${record.crashedPlayerName}` : `${record.rescuePlayerName}`;
        }
        return { disabled, message: disabledString };
    }

    render() {
        if (!this.state.slots.length) {
            return (
                <div>
                    <h2>Loading...</h2>
                    <p>If this remains, the server probably doesn't support slot permadeath or slot list export</p>
                </div>
            );
        }

        const cells = this.state.slots.sort().map((slot) => {
            const { disabled, message } = this.renderDisabledRecord(slot)
            return (
                <div style={styleCell} key={slot}>
                    <span>{slot}</span>
                    <span style={disabled ? { color: '#ee2222' } : { color: '#228b22' }}>{message}</span>
                </div>
            )
        })

        return (
            <div>
                <div style={styleHeader}>
                    <span>Slot</span>
                    <span>Crashed / Rescued by</span>
                </div>
                {cells}
            </div>
        )
    }
}
