import React, { CSSProperties } from 'react';

import CSARRecord, { CSARDisabled } from '../model/csarSlot';

import config from '../config.json';

const styleSlotsTable: CSSProperties = {
    overflow: 'auto',
}

interface CSARSlotsResponse {
    slots: string[],
    disabled?: {[key: string]: CSARDisabled},
    records?: {[key: string]: CSARRecord},
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

    private renderDisabledRecord(slot: string): string {
        if (!this.state.disabled) { return "OK" }
        const disabled = this.state.disabled[slot];
        let disabledRecord = !disabled ? "OK" : "Disabled"
        
        const record = this.state.records ? this.state.records[slot] : undefined;
        if (this.state.records && this.state.records[slot]) {
            const record = this.state.records[slot]
            disabledRecord = disabledRecord + " " + disabled ? `${record.crashedPlayerName}` : `${record.rescuePlayerName}`;
        }
        return disabledRecord;
    }

    render() {
        const cells = this.state.slots.sort().map((slot) => {
            const disabled = this.renderDisabledRecord(slot)
            return (
                <div key={slot}>
                    {slot} {disabled}
                </div>
            )
        })

        return (
            <div style={styleSlotsTable}>
                <b>Slot | Crashed / Rescued by</b>
                {cells}
            </div>
        )
    }

}
