## Yeoman angular-fullstack
- create a project: `yo angular-fullstack`
- create angularjs route: `yo angular-fullstack:route main`
- create backend api endpoint: `yo angular-fullstack:endpoint comment`

## npm command
- clean npm packages which are not defined in package.json: `npm prune`

## how to debug nodejs with Grunt project generated from the Angular-FullStack
1. `node-inspector --web-port` to query from any 5858 port of nodejs application. Let's call it a debug page.
2. start the Grunt project task: `grunt serve`, it listens 5858 port for debugging.
3. Go back to your debug page and wait for a while, you should see server's code there. Click to add some break point, please enjoy and here we go!
