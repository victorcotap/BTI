import React, { CSSProperties } from 'react';

const styleAbstract: CSSProperties = {
    fontWeight: "lighter",
    textAlign: "justify",
    padding: "5px 5px 5px 15px",
    lineHeight: "1.2rem"
}

const Abstract: React.FC = () => {
    return (
        <div style={styleAbstract}>
            <span>- 🌩  Zeus controlled A2A challenge meant to test the players capacity of organizing and running CAP correctly but nothing too crazy</span><br />
            <span>- 🗺 Players are given the position of the entire enemy A2G forces using the live map and have the opportunity to team up and plan their flight days in advance.</span><br />
            <span>- 💻  All progress is persisted to the unit level, server runs for 17h at a time. 1 life per airframe, don't die or risk severely impairing your team. Airframe life resets at mission restart (for now).</span><br />
            <span>- ⛑  Players can play the role of CSAR and rescue down pilots to bring back that airframe to life.</span><br />
            <span>- 🚁  FARPS slots are available near supply trucks but defended by enemy units, requiring players to clear it out before jumping in a slot.</span><br />
            <span>- 🛳  Airboss + Skipper enabled carrier for those looking for the proper Navy experience</span><br />
            <span>- 📻  Players are given the opportunity to have 2 Commanders/GCI max. They will be given some ground units to offer some combined arms support by the game master</span><br />
        </div>
    )
}

export default Abstract;