# hpc-app-container

[![Join the chat at https://gitter.im/hpc-app-container/community](https://badges.gitter.im/hpc-app-container/community.svg)](https://gitter.im/hpc-app-container/community?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

HPC Container Collection for [SJTU Center for High Performance Computing](https://docs.hpc.sjtu.edu.cn/).

Docker Hub Page: [https://hub.docker.com/r/chengshenggan/hpc-app-container](https://hub.docker.com/r/chengshenggan/hpc-app-container)

## Application List

### Relion

![Relion](https://github.com/Shenggan/hpc-app-container/workflows/Relion/badge.svg?branch=master)

Main Page: [http://www2.mrc-lmb.cam.ac.uk/relion](http://www2.mrc-lmb.cam.ac.uk/relion)

Version: [3.0.8](https://github.com/3dem/relion/releases/tag/3.0.8)

Usage:

```shell
# for docker user
docker pull chengshenggan/hpc-app-container:relion-3.0.8
# for singularity user
singularity pull docker://chengshenggan/hpc-app-container:relion-3.0.8
```

### Gromacs

![Gromacs](https://github.com/Shenggan/hpc-app-container/workflows/Gromacs/badge.svg?branch=master)

Main Page: [http://www.gromacs.org/](http://www.gromacs.org/)

Version: [2020](http://manual.gromacs.org/2020/download.html)

Usage:

```shell
# for docker user
docker pull chengshenggan/hpc-app-container:gromacs-2020
# for singularity user
singularity pull docker://chengshenggan/hpc-app-container:gromacs-2020
```

### Lammps

![Lammps](https://github.com/Shenggan/hpc-app-container/workflows/Lammps/badge.svg?branch=master)

Main Page: [https://lammps.sandia.gov/](https://lammps.sandia.gov/)

Version: [stable_3Mar2020](https://github.com/lammps/lammps/releases/tag/stable_3Mar2020)

Usage for GPU:

```shell
# for docker user
docker pull chengshenggan/hpc-app-container:lammps-gpu-2020
# for singularity user
singularity pull docker://chengshenggan/hpc-app-container:lammps-gpu-2020
```

Usage for Intel:

```shell
# for docker user
docker pull chengshenggan/hpc-app-container:lammps-intel-2020
# for singularity user
singularity pull docker://chengshenggan/hpc-app-container:lammps-intel-2020
```

### OpenFOAM

![OpenFOAM](https://github.com/Shenggan/hpc-app-container/workflows/OpenFOAM/badge.svg?branch=master)

Main Page: [https://openfoam.org/](https://openfoam.org/)

Version: [v8](https://openfoam.org/version/8)

Usage:

```shell
# for docker user
docker pull chengshenggan/hpc-app-container:openfoam-v8
# for singularity user
singularity pull docker://chengshenggan/hpc-app-container:openfoam-v8
```
