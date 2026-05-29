# AI Toolchain Architecture

High-level overview of the dotCMS AI toolchain, illustrating where we have flexibility to avoid vendor lock-in.  Items in Green are flexible for dotCMS to modfy by configuration. 

The **Anthropic Action** (used in GitOps) routes through dotCMS Cloud Compute but is constrained by IAM to Anthropic models only. All dotCMS-owned tools — **dotCMS Github Actions** — route through the same Cloud Compute layer _**AND**_ can reach any model in the LLM layer.

**Claude Code**, **Claude Chat**, and **Claude Co-Work** default to Anthropic Hosted Compute and can optionally route through dotCMS Cloud Compute (AWS Bedrock) instead but must still use the Anthropic Claude models in bedrock.

```mermaid
flowchart TD
    subgraph UI["UI Layer"]
        GH[GitHub]
        CC["Claude Code"]
        CCHAT["Claude Chat"]
        CCOWORK["Claude Co-Work"]
    end

    subgraph gitops["GitOps Zone"]
        ORCH["dotCMS Orchestrator"]
        AA["Anthropic Action"]
        DA["dotCMS Action"]
        ORCH --> AA
        ORCH --> DA
    end

    subgraph ANTHCOMP["Anthropic Hosted Compute"]
        AAPI["Anthropic API"]
    end

    subgraph CLOUD["dotCMS Cloud Compute"]
        bedrock["AWS Bedrock"]
    end

    subgraph LLM["LLM Layer"]
        AM["Anthropic Models"]
        OM["Other Models"]
    end

    GH --> ORCH
    CC -. "optional: must be Claude models" .-> CLOUD
    CC -->|"default"| ANTHCOMP
    CCHAT -->|"default"| ANTHCOMP
    CCOWORK -->|"default"| ANTHCOMP
    AA -->|"Must use Anthropic models"| CLOUD
    DA --> CLOUD
    CCOWORK -. "optional: must be Claude models" .-> CLOUD
    bedrock --> AM
    bedrock -->|"dotCMS tools only"| OM

    classDef flexible fill:#e8f5e9,stroke:#1b5e20,stroke-width:1px
    class DA,CC,CCOWORK,ORCH,bedrock flexible
```
