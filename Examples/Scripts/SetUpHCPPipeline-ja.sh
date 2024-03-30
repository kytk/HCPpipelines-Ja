#!/bin/echo This script should be sourced before calling a pipeline script, and should not be run directly:

#この行は編集しないでください
SAVEHCPPIPE="${HCPPIPEDIR:-}"

## この行を編集してください。HCPパイプラインのリポジトリの場所を示す環境変数です
## この変数を設定せず、 $HCPPIPEDIR が既に環境変数に設定されている場合、
## その変数が上にある $AVEHCPPIPE 変数経由で代わりに使用されます
export HCPPIPEDIR=

# 以下のセクションは編集しないでください。事前に変数を設定していた場合、それらを編集せずに HCPPIPEDIR を設定できます
if [[ -z "$HCPPIPEDIR" ]]
then
    if [[ -z "$SAVEHCPPIPE" ]]
    then
        export HCPPIPEDIR="$HOME/HCPpipelines"
    else
        export HCPPIPEDIR="$SAVEHCPPIPE"
    fi
fi

## 以下のセクションを編集してください。他の環境変数を設定します
export MSMBINDIR="${HOME}/pipeline_tools/MSM"
export MATLAB_COMPILER_RUNTIME=/export/matlab/MCR/R2017b/v93
export FSL_FIXDIR=/usr/local/fix
# 適切なバージョンの wb_command が $PATH に含まれていれば、 CARET7DIR はブランクでかまいません
export CARET7DIR=
export HCPCIFTIRWDIR="$HCPPIPEDIR"/global/matlab/cifti-matlab

## FSLを設定します (今の環境でまだFSLの設定をしていない場合)
## 以下の2行のコメントを外し (行頭の # を削除します) FSLDIR の設定を自分の環境にあわせてください
#export FSLDIR=/usr/local/fsl
#source "$FSLDIR/etc/fslconf/fsl.sh"

## FreeSurfer にどのバージョンのFSLを使用するか知らせます (変更する必要はないはずです)
export FSL_DIR="${FSLDIR}"

## FreeSurfer を設定します (今の環境でまだFreeSurferの設定をしていない場合)
## 以下の2行のコメントを外し (行頭の # を削除します)  FREESURFER_HOME の設定を自分の環境にあわせてください
#export FREESURFER_HOME=/usr/local/bin/freesurfer
#source ${FREESURFER_HOME}/SetUpFreeSurfer.sh > /dev/null 2>&1

# 提供されている MSM 設定ファイル以外のものを使いたい場合、以下を変更してください
export MSMCONFIGDIR="${HCPPIPEDIR}/MSMConfig"


# ---------------------------------------------------------
# この行より下はおそらく編集する必要はないでしょう
# ---------------------------------------------------------

# 設定を検証したり、 $PATH から情報を取得したりします

# FSL
if [[ -z "${FSLDIR:-}" ]]
then
    found_fsl=$(which fslmaths || true)
    if [[ ! -z "$found_fsl" ]]
    then
        #私達のスクリプトのように、fslmaths が $FSLDIR/bin/fslmaths という前提でいきます (neurodebian はこうではないので正当性の検証を行います)
        #前提が正しければ、 $() の内部で引用符が正しくネストされます
        export FSLDIR=$(dirname "$(dirname "$found_fsl")")
        #もし、 FSLDIR がなければ、 fslconf を source していなかったのでしょう
        if [[ ! -f "$FSLDIR/etc/fslconf/fsl.sh" ]]
        then
            echo "FSLDIR was unset, and guessed FSLDIR ($FSLDIR) does not contain etc/fslconf/fsl.sh, please specify FSLDIR in the setup script" 1>&2
            #NOTE: do not "exit", as this will terminate an interactive shell - the pipeline should sanity check a few things, and will hopefully catch it quickly
        else
            source "$FSLDIR/etc/fslconf/fsl.sh"
        fi
    else
        echo "fslmaths not found in \$PATH, please install FSL and ensure it is on \$PATH, or edit the setup script to specify its location" 1>&2
    fi
fi
if [[ ! -x "$FSLDIR/bin/fslmaths" ]]
then
    echo "FSLDIR ($FSLDIR) does not contain bin/fslmaths, please fix the settings in the setup script" 1>&2
fi

# Workbench
if [[ -z "$CARET7DIR" ]]
then
    found_wb=$(which wb_command || true)
    if [[ ! -z "$found_wb" ]]
    then
        CARET7DIR=$(dirname "$found_wb")
    else
        echo "wb_command not found in \$PATH, please install connectome workbench and ensure it is on \$PATH, or edit the setup script to specify its location" 1>&2
    fi
fi
if [[ ! -x "$CARET7DIR/wb_command" ]]
then
    echo "CARET7DIR ($CARET7DIR) does not contain wb_command, please fix the settings in the setup script" 1>&2
fi

# いくつかの特定のバージョンのソフトのパスを $PATH の前に追加します。そうすることで、絶対パスを使わずに済むようになります
export PATH="$CARET7DIR:$FSLDIR/bin:$PATH"

# ユーザーは不要だけれどもパイプラインの開発者達が編集する必要のあるその他のものを source します
# このようにすることで、もし我々がパイプラインの内部を若干変更したとしても、
# ユーザーはこれまでのセットアップファイルを使い続けることができます
if [[ ! -f "$HCPPIPEDIR/global/scripts/finish_hcpsetup.shlib" ]]
then
    echo "HCPPIPEDIR ($HCPPIPEDIR) appears to be set to an old version of the pipelines, please check the setting (or start from the older SetUpHCPPipeline.sh to run the older pipelines)"
fi

source "$HCPPIPEDIR/global/scripts/finish_hcpsetup.shlib"

