const fs = require('fs/promises');
const yaml = require('js-yaml');

module.exports = async ({ github, context, core, glob, exec, }) => {

    const patterns = ['gallery.yml', 'gallery.yaml']
    const globber = await glob.create(patterns.join('\n'));
    const files = await globber.glob();


    if (files.length === 0) {
        core.setFailed(`No gallery.yml or gallery.yaml found in the root of the repository.`);
    }

    if (files.length > 1) {
        core.setFailed(`More than one gallery.yml or gallery.yaml found in the root of the repository.`);
    }

    const contents = await fs.readFile(files[0], 'utf8');
    gallery = yaml.load(contents);

    if (!gallery.name) {
        core.setFailed(`No name property found in the gallery.yaml`);
    }

    if (!gallery.resourceGroup) {
        core.setFailed(`No resourceGroup property found in the gallery.yaml`);
    }

    const rows = [[
        { header: true, data: 'Name' },
        { header: true, data: 'Resource Group' }
    ], [
        { data: gallery.name },
        { data: gallery.resourceGroup }
    ]];

    await core.summary
        .addHeading('Gallery to publish images', 3)
        .addTable(rows).write();

    core.setOutput('name', gallery.name);
    core.setOutput('resourceGroup', gallery.resourceGroup);
};