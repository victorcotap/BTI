export function genColor (seed: number) {
    const color: number = Math.floor((Math.abs(Math.sin(seed) * 16777215)) % 16777215);
    let colorString: string = color.toString(16);
    // pad any colors shorter than 6 characters with leading 0s
    while(colorString.length < 6) {
        colorString = '0' + colorString;
    }

    return colorString;
}
