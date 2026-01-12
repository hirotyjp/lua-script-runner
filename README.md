
# Script Runner

## Basic syntax

| Command   | Description |
| --------- | ----------- |
|`*`        | Label       |
|`@`        | Command     |
|`#` or `;` | Comment     |


## Commands

### Progress/Condition control

| Command   | Description | Available options |
| --------- | ----------- | ----------------- |
|`@CALL`    | Call Sub-routine | <ul><li>file</li><li>label</li></ul> |
|`@RETURN`  | Return from Sub-routine| n/a |
|`@JUMP`    | Go to specific Label | <ul><li>file</li><li>label</li></ul> |
|`@IF`      | IF condition | ( <i>expression</i> ) |
|`@ELSEIF`  | ELSE IF condition | ( <i>expression</i> ) |
|`@ELSE`    | ELSE condition | n/a |
|`@ENDIF`   | END of IF condition | n/a |

### Screen control

| Command   | Description | Available options |
| --------- | ----------- | ----------------- |
|`@STYLE`   | Setup Link Style  | <ul><li>color = {0-1, 0-1, 0-1} (Normal color)</li><li>hover  = {0-1, 0-1, 0-1} (Hover color)</li><li>click  = {0-1, 0-1, 0-1} (Click color)</li><li>class</li></ul> |
|`@MESSAGE` | Setup Message Box | <ul><li>class</li><li>top</li><li>left</li><li>wifth</li><li>height</li></ul> |
|`@TEXT`    | Draw text in Message Box | <ul><li>speed (msec)</li><li>text</li></ul> |
|`@LINK`    | Draw Link| <ul><li>class</li><li>top</li><li>left</li><li>width</li><li>aligh</li><li>opacity (optional)</li></ul> |
|`@IMAGE`   | Draw Image | <ul><li>layer = bg/fg/msg</li><li>file</li><li>class</li><li>top</li><li>left</li><li>opacity (optional)</li></ul> |
|`@TRANS`   | Transition (Tween)<br>(This command use hump.timer internally) | <ul><li>class</li><li>duration</li><li>target = { <i>target variable name </i>= value}</li></ul> |
|`@CLEAR`   | Clear Contents from Layers| <ul><li>layer</li></ul> |
|`@SHADER`  | Set GLSL Shader | <ul><li>layer = bg/fg/msg</li><li>file</li><li>class</li><li>progress (dynamic value to be sent into glsl shader)</li></ul> |
|`@PURGE`   | Purge layer except for the latest image | <ul><li>layer = bg/fg/msg/controls/all</li></ul> |

### Wait control

| Command   | Description | Available options |
| --------- | ----------- | ----------------- |
|`@STOP`    | Completely stop | n/a |
|`@WAIT`    | Wait for transision | n/a |
|`@PAUSE`   | Wait for a key input | <ul><li>timeout (seconds)</li></ul> |

### Variables control

| Command   | Description | Available options |
| --------- | ----------- | ----------------- |
|`@CMD`     | Run specific lua command| ( <i>expression</i> ) |

### Others

| Command   | Description | Available options |
| --------- | ----------- | ----------------- |
|`@LOG`     | Print a variable | ( <i>expression</i> ) |
|`@ERROR`   | Stop with Error message | <i>message text</i> |
