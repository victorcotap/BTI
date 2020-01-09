import React from 'react';

const Rules: React.FC = () => {
    return (
        <div>
        <span>Rules for the PvP event</span>
        <p>
            The Blue (defending side) is considered loosing if the blue helicopters cannot complete their mission<br />
            The Red (attacking side) is considered loosing if blue helicopters manage to complete the mission<br />
            Team that has the least death (CSAR on Blue is available) at the end is deemed the winner<br />
            Every aircraft needs to be returned to a friendly airbase or carrier, unless CSAR within the timeframe of the OP (1h45)<br />
        </p>
        <p>
        - Blue will be balanced ~2: 1 compared to Red.Blue will have a single airport and smaller safe zone. Red will have more options and bigger safe zone<br />
        - All awacs and tankers are vulnerable, no EWRS is provided.<br />
        - There is no guarantee you won\'t be fighting and aircraft of the same type, IFF and proper combat techniques are paramount to avoid friendly fire.<br />
        - The game master can forbid Red movement for balance purposes, know that you must agree with its command.Balance could be achieved by throwing AI into the mix.<br />
        - Each side can be given up to two human GCI, GCIs are forbidden from calling missile shots(side looses the game instantly)<br />
        </p>
</div>

    )
}

export default Rules;
