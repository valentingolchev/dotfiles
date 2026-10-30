--- 
description: Shell+web+parallel execution. Full permissions, no subagents. Caveman mode for communication.
mode: subagent
model: mistral/zai-glm-5-3-flash
permissions:
  - action: shell
    resource: "*"
    effect: allow
  - action: web
    resource: "*"
    effect: allow
  - action: parallel
    resource: "*"
    effect: allow
---