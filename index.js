/**
 * Most of this code has been copied from the following GitHub Action
 * to make it simpler or not necessary to install a lot of
 * JavaScript packages to execute a shell script.
 *
 * https://github.com/ad-m/github-push-action/blob/fe38f0a751bf9149f0270cc1fe20bf9156854365/start.js
 */
const core = require('@actions/core');
const spawn = require('child_process').spawn;
const path = require("path");

const environmentName = core.getInput('environmentName');
const backendBucket = core.getInput('backendBucket');
const regionName = core.getInput('regionName');
const profileName = core.getInput('profileName');
const backendDynamoDB = core.getInput('backendDynamoDB');
const scriptPath = core.getInput('scriptPath');



const exec = (cmd, args=[]) => new Promise((resolve, reject) => {
    console.log(`Started: ${cmd} ${args.join(" ")}`)
    const app = spawn(cmd, args, { stdio: 'inherit' });
    app.on('close', code => {
        if(code !== 0){
            err = new Error(`Invalid status code: ${code}`);
            err.code = code;
            return reject(err);
        };
        return resolve(code);
    });
    app.on('error', reject);
});

const main = async () => {
    await exec('bash', [path.join(__dirname, './entrypoint.sh'),environmentName,backendBucket,regionName,profileName,backendDynamoDB,scriptPath]);
};

main().catch(err => {
    console.error(err);
    console.error(err.stack);
    process.exit(err.code || -1);
})