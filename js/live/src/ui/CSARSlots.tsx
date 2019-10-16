import React, { CSSProperties } from 'react';

const fakeSlots = [
    "F18",
    "F18 2",
    "F18",
    "F18 2",
    "F18",
    "F18 2 dsfgjkhdsfkjfghkjdfghjkdhfghdgjkhdjhgjkdfhgk",
    "F18",
    "F18 2",
    "F18",
    "F18 2",
    "F18",
    "F18 2",
]

const CSARSlots: React.FC = () => {
    const cells = fakeSlots.map((slot) => {
        return <p>{slot}</p>
    })
    
    return (
        <div>
            {cells}
        </div>
    )
}

export default CSARSlots