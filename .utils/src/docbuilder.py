#!/usr/env python

import json,os,argparse,calendar as cal

CURR_FILE = os.path.abspath(__file__)
CURR_DIR = os.path.dirname(CURR_FILE)
HW_DIR = os.path.dirname(CURR_DIR)
JSON_FILE = os.path.join(CURR_DIR,'classes.json')

PROMPTS = {
	0:"Path: {0}\nDoes not exist.  Create? (Y/N) ",
	1:"Path: {0}\nFile: {1}\nFile exists. Overwrite? (Y/N) ",
	2:"Using:\n\tPath: {0}\n\tFilename: {1}\nGenerate Document? (Y/N) ",
	}

class DocGen(object):
	curr_date = cal.datetime.datetime.now
	delt = cal.datetime.timedelta
	jn = os.path.join
	def __init__(self,**kwargs):
		self.conf = kwargs.get('json_file',JSON_FILE)
		self.cn_str = str(kwargs.get('course',None))
		_hw = kwargs.get('hwnum',1)
		self.hw = str(_hw)
		self.hw_zpad = "%02i"%(_hw)
		self.dued = kwargs.get('due_date',None)
		self.DT = kwargs.get('date',self.curr_date())
		if self.DT.month <= 5:
			self.sem_key = 'S'
		elif 5 < self.DT.month < 8:
			self.sem_key = 'U'
		else:
			self.sem_key = 'F'
		self.sem_key+="%i"%( self.DT.year %2000 )
		with open(self.conf,'r') as f:
			D = json.load(f)
		self.sem_courses = D['courses'][self.sem_key]
		self.templates = D['templates']

	def datecalc(self,strin):
		if self.dued:
			dd = cal.datetime.datetime.strptime(strin,"%Y%m%d")
			dueday = dd.day
			duedelta = 0
		else:
			dueday = getattr(cal,strin.upper())
			duedelta = (dueday - self.DT.weekday()) % 7
			if duedelta == 0:
				duedelta+=7
		D = self.DT + self.delt(days=duedelta)
		return D
	def prompter(self,prompt):
		D={'Y':True,'N':False}
		while True:
			res = raw_input(prompt)
			if res == 'Y' or res == 'N':
				break
			else:
				print "Please enter Y or N"
		return D[res]
	def joinext(self,*args):
		pth = os.path.join(*args)
		return os.path.exists(pth)

	def dirtest_resp(self,*args):
		tf = self.joinext(*args)
		if len(args)==1 and not tf:
			prompt = PROMPTS[0].format(*args)
			return tf,self.prompter(prompt)
		if len(args)==2 and tf:
			prompt = PROMPTS[1].format(*args)
			return tf,self.prompter(prompt)
		else:
			return tf,True

	def pth_build(self):
		me_str,asn_type,ext_type = 'SRG','HW','tex'
		hw_str = "%s%s"%(asn_type,self.hw_zpad)
		cn_pth = os.path.join(HW_DIR,self.cn_str)
		hn_pth = os.path.join(asn_type,hw_str)
		P = os.path.join(cn_pth,hn_pth,me_str)
		fname = '.'.join([me_str,self.cn_str,hw_str,ext_type])
		pexist,pathmake = self.dirtest_resp(P)
		dexist,doc_make = self.dirtest_resp(P,fname)
		
		if not pexist and pathmake:
			os.makedirs(P,mode=0774)
		elif pexist and not pathmake:
			P = HW_DIR
		if dexist and not doc_make:
			fname = '.'.join([me_str,self.cn_str,hw_str,'v2',ext_type])
		return P,fname

	def getheader(self,plates):
		header = '\n'.join(self.templates['header'])
		head2 = '\n'.join(self.templates['topopulate'])
		_names = map(plates.get,['COURSE_NAME','COURSE_TITLE'])
		name = ' \\\\ '.join(_names)
		due = self.datecalc(self.dued or plates['DUE_DAY'])
		data = {
			'FULL_COURSE_NAME': name,
			'DUE_DT': due.strftime("%a, %b %d, %Y"),
			'HW_NUM': self.hw,
			}
		return '\n'.join([header,head2.format(**data)])

	def dictToTeX(self):
		course_meta = self.sem_courses[self.cn_str]
		course_temp = course_meta['TEMPLATES']
		out = self.getheader(course_meta)
		for c in course_temp:
			out+='\n'
			out+='\n'.join(self.templates[c])
		return out
	def build(self):
		P,f = self.pth_build()
		D = self.dictToTeX()
		prompt = PROMPTS[2].format(*[P,f])
		dobuild = self.prompter(prompt)
		if not dobuild:
			return "aborted...\nNothing created"
		writeto = os.path.join(P,f)
		with open(writeto,'w') as texfile:
			texfile.write(D)
		return "Created %s" %(writeto)

parser = argparse.ArgumentParser(description='A document generator')
parser.add_argument('--course','-c', dest='course', type=int, help='Course Number',required=True)
parser.add_argument('--hw-number','-n', dest='hwnum', type=int, help='Home work number',required=True)
parser.add_argument('--date','-d', dest='due_date', type=str, help='Custom Due Date')

if __name__ == '__main__':
	_args = parser.parse_args()
	args = vars(_args)
	argdict = {i:j for i,j in args.iteritems() if j}
	D = DocGen(**argdict)
	action = D.build()
	print action








