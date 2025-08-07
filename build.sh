#!/bin/bash
_VERSIONING="build"
_TAG="false"
_PROFILE="HJM"
_MIGRATIONS="true"

NOP=""

function safe_rm() {
	[[ -f "$1" ]] && rm "$1"
}

function _help_and_quit() {
	echo "$(basename "$1") construye el proyecto e incrementa el número de versión." 1>&2
	echo -e "\t-M Incrementa el número de versión mayor (p.e. X.5.203)." 1>&2
	echo -e "\t-m Incrementa el número de versión menor (p.e. 1.X.203)." 1>&2
	echo -e "\t-n No incrementar el número de versión." 1>&2
	echo -e "\t-N No empaquetar archivos de migraciones." 1>&2
	echo -e "\t-P <name> Selecciona el profile de maven a construir." 1>&2
	echo -e "\t-t Genera una etiqueta en la versión actual del proyecto." 1>&2
	echo -e "\t-h Mostrar este texto de ayuda." 1>&2
	echo -e "\nPor default, el script:" 1>&2
	echo -e "\t* Hace PULL de la rama actual de GIT." 1>&2
	echo -e "\t* Borra el contenido del directorio ./target (si existe)" 1>&2
	echo -e "\t* Incrementa el número de build del proyecto (1.0.XX) y genera un commit con el" 1>&2
	echo -e "\t  cambio de número de versión (a menos que se use la opción -n)" 1>&2
	echo -e "\t* Compila el proyecto con el perfil HJM y genera el archivo WAR." 1>&2
	echo -e "\t* Renombra el archivo WAR con el timestamp actual: (p.e." 1>&2
	echo -e "\t  emotionNPT_20241123_1507.war)" 1>&2
	echo -e "\t* Crea un archivo comprimido con todos los cambios de base de datos en el" 1>&2
	echo -e "\t  directorio ./target (p.e. migrations_20241123_1507.tar.bz2)" 1>&2
	exit 1
}

while getopts ":mMnNtP:h" opt; do
  case $opt in
    m)  _VERSIONING="minor" ;;
    M)  _VERSIONING="major" ;;
    n)  _VERSIONING="none" ;;
    N)  _MIGRATIONS=false ;;
    t)  _TAG=true ;;
    P)  _PROFILE="$OPTARG" ;;
    h)  _help_and_quit "$0";;
    \?)
        echo "Invalid option: $OPTARG" 1>&2
        _help_and_quit "$0";;
    :)
        echo "Invalid option: $OPTARG requires an argument" 1>&2
        _help_and_quit "$0";;
  esac
done

$NOP git pull

if [[ $_VERSIONING != "none" ]]; then
	version=$(grep '<version>' pom.xml | head -n1 | cut -d'>' -f 2 | cut -d'<' -f 1)

	case $_VERSIONING in
		build)
			version=$(awk -F'.' '{print $1"."$2"."$3+1}' <<< ${version} | sed 's/[.]$//')
			;;
		minor)
			version=$(awk -F'.' '{print $1"."$2+1".0"}' <<< ${version} | sed 's/[.]$//')
			;;
		major)
			version=$(awk -F'.' '{print $1+1".0.0"}' <<< ${version} | sed 's/[.]$//')
			;;
		*)
			echo "unsupported versioning: $_VERSIONING" 1>&2
			exit 1
			;;
	esac

	mvn -U versions:set -DnewVersion=${version}
fi

rm -Rf ./target/

$NOP mvn clean package -P${_PROFILE} || exit 1

timestamp=$(date "+%Y%m%d_%H%M")
war_name="emotion_HJM_${timestamp}.war"

[[ -f ./target/emotion.war ]] && mv ./target/emotion.war "./target/${war_name}"

if [[ $_VERSIONING != "none" ]]; then
	$NOP git add pom.xml
	message="Version ${version} generated on $(date) by $(git config user.name) ($(git config user.email))"
	$NOP git commit -m "$message"

	# Create a tag for the version
	if [[ "$_TAG" == "true" ]]; then
		$NOP git tag -a "RELEASE_CANDIDATE_${version}" -m "$message"
	fi

	$NOP git push --tags

	safe_rm pom.xml.versionsBackup
fi

if [[ $_MIGRATIONS == "true" ]]; then
	migrations_name="migrations_${timestamp}.tar.bz2"
	tar -cvjSf "./target/${migrations_name}" -C ./src/main/resources/migrations/ .
fi

pushd ./target/
if [[ $_MIGRATIONS == "true" ]]; then
	md5sum "${war_name}" "${migrations_name}" > "md5sums_${timestamp}.txt"
else
	md5sum "${war_name}" > "md5sums_${timestamp}.txt"
fi
popd
