import * as vscode from 'vscode';
import { AzureDevCliEnvironments } from './AzureDevCliEnvironments';
import { AzureDevCliModel, AzureDevCliModelContext, RefreshHandler } from "./AzureDevCliModel";
import { AzureDevCliServices } from './AzureDevCliServices';
import { WorkspaceResource } from './ResourceGroupsApi';

export class AzureDevCliApplication implements AzureDevCliModel {
    constructor(
        private readonly resource: WorkspaceResource,
        private readonly refresh: RefreshHandler) {
    }

    readonly context: AzureDevCliModelContext = {
        configurationFile: vscode.Uri.file(this.resource.id)
    };

    getChildren(): AzureDevCliModel[] {
        return [
            new AzureDevCliServices(this.context),
            new AzureDevCliEnvironments(this.context, this.refresh)
        ];
    }

    getTreeItem(): vscode.TreeItem {
        const treeItem = new vscode.TreeItem(this.resource.name, vscode.TreeItemCollapsibleState.Expanded);

        treeItem.contextValue = 'ms-azuretools.azure-dev.views.workspace.application';
        treeItem.iconPath = new vscode.ThemeIcon('azure');

        return treeItem;
    }
}