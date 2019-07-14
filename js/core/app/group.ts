enum category { Airplane = "Airplane", Ground = "Ground Unit"}
enum coalition {Blue = 2, Red = 1}

export default interface Group {
    alive: boolean,
    category: category,
    coalition: coalition,
    latitude: number,
    longitude: number,
    type: string,
}
