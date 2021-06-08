# PNTester

PNTester is a mac app that let you push notifications on simulator. Just add simulator, select a payload from the sample payloads and click on Push. That's all you need to do. 

This is how you can add a simulator 👇🏼

```bash
 - Open Xcode
 - Go to Window -> Devices & Simulators
 - Select simulators
 - Select the simulator you want to add, and copy its identifier.
 - In the app, click on 'Add Simulator', enter the name and identifier of simulator and click 'Save'.    
```

## Installation

Just clone/download the repo, build it, and the move PNTester.app from Products directory to your Applications or Desktop or wherever from you would like to access it.

## Usage

[Video showing usage of the app](https://drive.google.com/file/d/1SQomyDXSDiHtZok9UXB11Nh3qwWgS98-/view?usp=sharing)


## Want to push notifications from terminal?

Just run this command from terminal (App is internally using the same).
```bash
xcrun simctl push "<SIMULATOR IDENTIFIER>" "<PATH TO APNS FILE>"
```

## Want to understand the source code?
The complete explanation can be found [here](https://youtu.be/--W3qMzyQfI).

## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

## License
[MIT](https://choosealicense.com/licenses/mit/)

## Happy Coding 🍻 
