
# Script Runner

## Basic syntax

| Command   | Description |
| --------- | ----------- |
|`*`        | Label       |
|`@`        | Command     |
|`#` or `;` | Comment     |


## Commands

### Progress/Condition control

| Command   | Description |
| --------- | ----------- |
|`@CALL`     | Call Sub-routine |
|`@RETURN`   | Return from Sub-routine|
|`@JUMP`     | Go to specific Label |
|`@IF`       | IF condition |
|`@ELSE`     | ELSE condition |
|`@ELSEIF`   | ELSE IF condition|
|`@ENDIF`    | END of IF condition |

### Screen control

| Command   | Description |
| --------- | ----------- |
|`@STYLE`    | Setup Link Style  |
|`@MESSAGE`  | Setup Message Box |
|`@TEXT`     | Draw text in Message Box |
|`@LINK`     | Draw Link|
|`@IMAGE`    | Draw Image |
|`@TRANS`    | Transition |
|`@CLEAR`    | Clear Contents from Layers|
|`@SHADER`   | Set Shader |
|`@PURGE`    | Purge all images in a layer except for the latest image |

### Wait control

| Command   | Description |
| --------- | ----------- |
|`@STOP`     | Completely stop |
|`@WAIT`     | Wait for transision |
|`@PAUSE`    | Wait for key innput |

### Variables control

| Command   | Description |
| --------- | ----------- |
|`@CMD`      | |

### Others

| Command   | Description |
| --------- | ----------- |
|`@LOG`      | Print a variable |
|`@ERROR`    | Stop with Error message |
